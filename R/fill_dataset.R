options(java.parameters = "-Xmx16g")

library("rjwsacruncher")
library("rjd3workspace")
library("rjd3providers")
library("rjd3x13")
library("RJDemetra")
library("rjdworkspace")
library("tidyr")
library("tssim")

source("R/utils.R")

nb_tent <- 2L
nb_bench <- 2L
big_data <- TBox::get_data(path = "data/data_10000.csv")
big_data$date <- as.Date(big_data$date)

for (b in seq_len(nb_bench)) {
    cat("Bench nb ", b, "\n\n")
    nb_years <- sample(c(5L, 10L, 15L, 20L), size = 1L)
    this_time <- data.frame(
        nb_series = integer(nb_tent),
        nb_years = rep(nb_years, nb_tent),
        cruncher_v2 = numeric(nb_tent),
        cruncher_v3 = numeric(nb_tent),
        RJDemetra = numeric(nb_tent),
        rjd3x13 = numeric(nb_tent)
    )

    for (tentative in seq_len(nb_tent)) {
        cat("\nTentative", tentative, "à", toString(Sys.time()), "\n")

        cat("Préparation des données\n")
        path_data <- tempfile(fileext = ".csv") |>
            normalizePath(mustWork = FALSE)
        path_ws_v2 <- tempfile(fileext = ".xml") |>
            normalizePath(mustWork = FALSE)
        path_ws_v3 <- tempfile(fileext = ".xml") |>
            normalizePath(mustWork = FALSE)

        nb_series <- sample(2L:10000L, size = 1L)
        cat("Nb series: ", nb_series, "\n")
        this_time[tentative, "nb_series"] <- nb_series

        data <- big_data[, seq_len(nb_series + 1L)] |>
            head(nb_years * 12L)
        data_ts <- ts(data[, -1L], start = 2000L, frequency = 12L)
        TBox::write_data(data, path_data)

        # Préparation du WS v3
        cat("Préparation du WS v3\n")
        jws <- jws_open("WS/ws_v3.xml")
        jsap <- jws_sap(jws, 1L)
        for (k in sort(
            setdiff(seq_len(10000L), seq_len(nb_series)),
            decreasing = TRUE
        )) {
            rjd3workspace::remove_sa_item(jsap, k)
        }
        rjd3workspace::txt_update_path(jws, new_path = path_data)
        rjd3workspace::save_workspace(jws, file = path_ws_v3)

        # Préparation du WS v2
        cat("Préparation du WS v2\n")
        ws <- RJDemetra::load_workspace(normalizePath("WS/ws_v2.xml"))
        sap <- RJDemetra::get_object(ws, pos = 1L)
        for (k in sort(
            setdiff(seq_len(10000L), seq_len(nb_series)),
            decreasing = TRUE
        )) {
            rjdworkspace::remove_sa_item(sap = sap, pos = k)
        }
        RJDemetra::save_workspace(workspace = ws, file = path_ws_v2)
        rjdworkspace::update_path(
            ws_xml_path = path_ws_v2,
            raw_data_path = path_data,
            verbose = FALSE
        )

        cat("Coup de cruncher v3\n")
        time_cruncher_v3 <- call_cruncher(
            path_ws = path_ws_v3,
            cruncher_bin_directory = normalizePath(
                "../software/jwsacruncher-3.6.0/bin/"
            ),
            v3 = TRUE
        )

        cat("Coup de cruncher v2\n")
        time_cruncher_v2 <- call_cruncher(
            path_ws = path_ws_v2,
            cruncher_bin_directory = normalizePath(
                "../software/jwsacruncher-2.2.6/bin/"
            ),
            v3 = FALSE
        )

        cat("Coup de rjd3x13\n")
        time_rjd3x13 <- call_rjd3x13(data_ts)

        cat("Coup de RJDemetra\n")
        time_rjdemetra <- call_RJDemetra(data_ts)

        this_time[tentative, "cruncher_v2"] <- time_cruncher_v2[3L]
        this_time[tentative, "cruncher_v3"] <- time_cruncher_v3[3L]
        this_time[tentative, "RJDemetra"] <- time_rjdemetra[3L]
        this_time[tentative, "rjd3x13"] <- time_rjd3x13[3L]
    }

    # Enregistrement
    library("aws.s3")

    BUCKET <- "tbarthelemy"
    FILE_KEY_S3 <- "Compare-time-rjdverse/output/time.csv"

    time_total <- aws.s3::s3read_using(
        FUN = TBox::get_data,
        object = FILE_KEY_S3,
        bucket = BUCKET,
        opts = list(region = "")
    )

    new_time_total <- rbind(time_total, this_time)

    aws.s3::s3write_using(
        new_time_total,
        FUN = TBox::write_data,
        object = FILE_KEY_S3,
        bucket = BUCKET,
        opts = list(region = "")
    )

    FILE_KEY_OUT_S3 <- file.path(
        "Compare-time-rjdverse",
        "ARCHIVES",
        paste0("time-", Sys.time(), ".csv")
    )

    aws.s3::s3write_using(
        this_time,
        FUN = TBox::write_data,
        object = FILE_KEY_OUT_S3,
        bucket = BUCKET,
        opts = list(region = "")
    )
}


library("rjwsacruncher")
library("rjd3toolkit")
library("rjd3workspace")
library("rjd3providers")
library("rjd3x13")
library("RJDemetra")
library("rjdworkspace")
library("ggplot2")
library("tidyr")
library("tssim")
library("plotly")

source("R/utils.R")

nb_tent <- 1000
data_time <- data.frame(
    nb_series = integer(nb_tent),
    cruncher_v2 = numeric(nb_tent),
    cruncher_v3 = numeric(nb_tent),
    RJDemetra = numeric(nb_tent),
    rjd3x13 = numeric(nb_tent)
)

for (tentative in seq_len(nb_tent)) {

    cat("\nTentative ", tentative, "\n")

    cat("Préparation des données\n")
    path_data <- tempfile(fileext = ".csv") |> normalizePath(mustWork = FALSE)
    path_ws_v2 <- tempfile(fileext = ".xml") |> normalizePath(mustWork = FALSE)
    path_ws_v3 <- tempfile(fileext = ".xml") |> normalizePath(mustWork = FALSE)

    nb_series <- sample(2:1000, size = 1L)
    cat("Nb series: ", nb_series, "\n")
    data_time[tentative, "nb_series"] <- nb_series

    data <- create_data(n = nb_series)
    data_ts <- ts(data[, -1], start = 2000, freq = 12)
    TBox::write_data(data, path_data)

    # Préparation du WS v3
    cat("Préparation du WS v3\n")
    jws <- jws_new()
    jsap <- jws_sap_new(jws, "SAP1")
    for (k in seq_len(nb_series)) {
        ts_object <- txt_series(
            file = path_data,
            series = k,
            delimiter = "SEMICOLON"
        )
        rjd3workspace::add_sa_item(jsap = jsap, name = colnames(data)[k], x = ts_object$data, spec = rjd3x13::x13_spec())
    }
    rjd3workspace::save_workspace(jws, file = path_ws_v3)

    # Préparation du WS v2
    cat("Préparation du WS v2\n")
    ws <- RJDemetra::load_workspace(normalizePath("WS/ws_v2.xml"))
    sap <- RJDemetra::get_object(ws, pos = 1L)
    for (k in sort(setdiff(seq_len(1000), seq_len(nb_series)), decreasing = TRUE)) {
        rjdworkspace::remove_sa_item(sap = sap, pos = k)
    }
    RJDemetra::save_workspace(workspace = ws, file = path_ws_v2)
    rjdworkspace::update_path(ws_xml_path = path_ws_v2, raw_data_path = path_data, verbose = FALSE)

    cat("Coup de cruncher v3\n")
    time_cruncher_v3 <- call_cruncher(path_ws_v3, normalizePath("~/work/software/jwsacruncher-3.5.1/bin/"), v3 = TRUE)

    cat("Coup de cruncher v2\n")
    time_cruncher_v2 <- call_cruncher(path_ws_v2, normalizePath("~/work/software/jwsacruncher-2.2.6/bin/"), v3 = TRUE)

    cat("Coup de rjd3x13\n")
    time_rjd3x13 <- call_rjd3x13(data_ts)

    cat("Coup de RJDemetra\n")
    time_rjdemetra <- call_RJDemetra(data_ts)

    data_time[tentative, "cruncher_v2"] <- time_cruncher_v2[3]
    data_time[tentative, "cruncher_v3"] <- time_cruncher_v3[3]
    data_time[tentative, "RJDemetra"] <- time_rjdemetra[3]
    data_time[tentative, "rjd3x13"] <- time_rjd3x13[3]
}


p <- tidyr::pivot_longer(data_time, cols = -nb_series) |>
    ggplot2::ggplot() +
    ggplot2::geom_point(aes(x = nb_series, y = value, color = name)) +
    theme_minimal()

# le rendre interactif
ggplotly(p) |>
    layout(legend = list(itemclick = "toggleothers"))

save.image("data.RData")

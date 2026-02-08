create_data <- function(nb_series = 10L, nb_years = 12L) {
    series <- lapply(
        X = seq_len(nb_series),
        FUN = \(k) as.numeric(tssim::sim_monthly(nb_years)[, 1L])
    )
    names(series) <- sapply(
        X = seq_len(nb_series),
        FUN = \(k) {
            paste(sample(letters, size = 5L, replace = TRUE), collapse = "")
        }
    )
    series <- data.frame(
        date = seq.Date(
            from = as.Date("2000-01-01"),
            length.out = nb_years * 12L,
            by = "month"
        ),
        series
    )
    return(series)
}

call_cruncher <- function(
    path_ws,
    cruncher_bin_directory = normalizePath("./jwsacruncher-3.6.0/bin/"),
    v3 = TRUE
) {
    options(
        v3 = v3,
        is_cruncher_v3 = v3,
        cruncher_bin_directory = cruncher_bin_directory
    )

    computing_time <- system.time({
        rjwsacruncher::cruncher_and_param(
            workspace = path_ws,
            # Pour renommer les dossiers en sortie
            rename_multi_documents = FALSE,
            # Pour remplacer les sorties existantes
            delete_existing_file = FALSE,
            # Politique de rafraichissement
            policy = "complete",
            # Format de sortie des tables
            csv_layout = "vtable",
            log_file = "output_cruncher.log"
        )
    })

    return(computing_time)
}

call_rjd3x13 <- function(data_ts) {
    computing_time <- system.time({
        for (k in seq_len(ncol(data_ts))) {
            rjd3x13::x13(ts = data_ts[, k])
        }
    })

    return(computing_time)
}

call_RJDemetra <- function(data_ts) {
    computing_time <- system.time({
        for (k in seq_len(ncol(data_ts))) {
            RJDemetra::x13(series = data_ts[, k])
        }
    })

    return(computing_time)
}

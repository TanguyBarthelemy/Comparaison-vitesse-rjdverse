
create_data <- function(n = 10) {
    series <- lapply(seq_len(n), \(k) as.numeric(tssim::sim_monthly(12)[, 1]))
    names(series) <- sapply(seq_len(n), \(k) paste0(sample(letters, size = 5, replace = TRUE), collapse = ""))
    series <- data.frame(
        date = seq.Date(from = as.Date("2000-01-01"), length.out = 144, by = "month"),
        series
    )
    return(series)
}

call_cruncher <- function(path_ws, cruncher_bin_directory = normalizePath("./jwsacruncher-3.5.1/bin/"), v3 = TRUE) {
    options(
        v3 = v3,
        is_cruncher_v3 = v3,
        cruncher_bin_directory = cruncher_bin_directory
    )

    computing_time <- system.time({
        cruncher_and_param(
            workspace = path_ws,
            rename_multi_documents = FALSE, # Pour renommer les dossiers en sortie
            delete_existing_file = FALSE, # Pour remplacer les sorties existantes
            policy = "complete", # Politique de rafraichissement
            csv_layout = "vtable", # Format de sortie des tables
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

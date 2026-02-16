
library("ggplot2")
library("plotly")
library("dplyr")


time_total <- TBox::get_data("~/../Downloads/time.csv")

mod_rjd3x13 <- lm(rjd3x13 ~ nb_series, data = time_total)
mod_RJDemetra <- lm(RJDemetra ~ nb_series, data = time_total)
mod_cruncher_v2 <- lm(cruncher_v2 ~ nb_series + log(nb_series),
                      data = time_total)
mod_cruncher_v3 <- lm(cruncher_v3 ~ nb_series + log(nb_series),
                      data = time_total)

df_raw <- time_total |>
    tidyr::pivot_longer(
        cols = -c(nb_series, nb_years),
        values_to = "time", names_to = "method"
    ) |>
    mutate(type = "realised")

gr_list <- list()

for (year in c(5, 10, 12, 15, 20)) {

    df_20 <- df_raw |>
        filter(nb_years == year) |>
        select(nb_series, method, time) %>%
        mutate(time_lin = lm(formula = time ~ method * nb_series + method * log(nb_series), data = .)$fitted.values)

    gr1 <- df_20 |>
        ggplot(data = _, aes(x = nb_series, color = method)) +
        geom_point(
            size = 0.2, alpha = 0.3, mapping = aes(y = time)
        ) +
        geom_line(mapping = aes(y = time_lin)) +
        ggtitle(paste0("Computation time for series of ", year, " years"),
                subtitle = "datasets containing 2 to 10000 series")

    df_20 <- df_raw |>
        filter(nb_years == year, nb_series <= 1000) |>
        select(nb_series, method, time) %>%
        mutate(time_lin = lm(formula = time ~ method * nb_series + method * log(nb_series), data = .)$fitted.values)

    gr2 <- df_20 |>
        ggplot(data = _, aes(x = nb_series, color = method)) +
        geom_point(
            size = 0.2, alpha = 0.3, mapping = aes(y = time)
        ) +
        geom_line(mapping = aes(y = time_lin)) +
        ggtitle(paste0("Computation time for series of ", year, "years"),
                subtitle = "datasets containing 2 to 1000 series")

    gr_list <- c(gr_list, list(gr1, gr2))
}

pdf(file = "output/plots.pdf")
for (k in gr_list) {
    print(k)
}
dev.off()

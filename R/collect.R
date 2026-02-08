library("aws.s3")
library("TBox")
library("dplyr")

BUCKET <- "tbarthelemy"
FILE_KEY_S3 <- "data/time.csv"

time_total <-
    s3read_using(
        FUN = get_data,
        object = FILE_KEY_S3,
        bucket = BUCKET,
        opts = list(region = "")
    )

time_total <- time_total |>
    filter(!is.na(rjd3x13))

write_data(time_total, "output/time.csv")

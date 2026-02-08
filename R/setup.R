install.packages(c(
    "RJDemetra",
    "rjwsacruncher",
    "TBox",
    "tssim",
    "remotes",
    "ggplot2",
    "tidyr",
    "plotly",
    "rjd3x13",
    "rjdworkspace"
))

remotes::install_github("rjdverse/rjd3providers", upgrade = "never")
remotes::install_github("rjdverse/rjd3workspace", upgrade = "never")

system("mc cp -recursive s3/tbarthelemy/Compare-time-rjdverse/data .")
system("mc cp -recursive s3/tbarthelemy/Compare-time-rjdverse/WS .")

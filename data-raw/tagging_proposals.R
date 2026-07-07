## This code prepares `tagging_proposals` dataset
library(osmproposals)


# Tagging proposals -------------------------------------------------------

proposals <- get_tagging_proposals(max_items = 1000)

proposals_inactive <- get_tagging_proposals(
  statuses = c(
    "Draft",
    "Voting",
    "Abandoned",
    "Canceled",
    "Obsoleted",
    "Inactive"
  ),
  max_items = 1000
)

proposals <- proposals |>
  dplyr::bind_rows(proposals_inactive) |>
  dplyr::mutate(
    status = forcats::fct_relevel(
      as.factor(status),
      "Approved",
      "Rejected",
      "Voting",
      "Proposed",
      "Draft",
      "Abandoned",
      "Canceled",
      "Obsoleted"
    )
  )

usethis::use_data(proposals, overwrite = TRUE)


# Proposals votes ---------------------------------------------------------

proposals_votes <- get_proposals_votes(proposals$fullurl)

usethis::use_data(proposals_votes, overwrite = TRUE)

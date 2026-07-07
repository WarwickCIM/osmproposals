# Retrieve a list of tagging proposals

Retrieves all tagging proposals in OSM's wiki by querying mediawiki's
API and provides basic metadata.

## Usage

``` r
get_tagging_proposals(
  statuses = c("Rejected", "Approved", "Proposed"),
  max_items = 5,
  info = TRUE,
  voting_summary = TRUE,
  file = NULL
)
```

## Arguments

- statuses:

  a string or vector containing proposal's statuses to look for.

- max_items:

  a integer specifiying the the maximum number of members to retrieve
  for each category. Set to 5 by default.

- info:

  a boolean. Specifies whether to retrieve or not proposals' stats. Set
  TRUE by default.

- voting_summary:

  a boolean. Specifies whether to retrieve or not proposals' voting
  summary. Set TRUE by default.

- file:

  a string containing the file path to store the dataset.

## Value

a dataframe containing tagging proposals and associated metadata (see
[`proposals`](https://warwickcim.github.io/osmproposals/reference/proposals.md)
for a description of its metadata).

## Examples

``` r
proposals <- get_tagging_proposals("Proposed")
#> 
#> ── Retrieving proposals by status ──────────────────────────────────────────────
#> Retrieving Proposed proposals
#> ✔ Retrieved 5 proposals.
#> 
#> ── Retrieving proposals' details ───────────────────────────────────────────────
#> ✔ Retrieved details to 5 proposals.
#> 
#> ── Retrieving proposals' information ───────────────────────────────────────────
#> Webscrapping ■■■■■■■■■■■■■                     40% | ETA:  2s
#> Webscrapping ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■  100% | ETA:  0s
#> 
#> ── Retrieving proposals' voting summaries ──────────────────────────────────────
head(proposals)
#> # A tibble: 5 × 28
#>   status   title                  sortkeyprefix timestamp           pagelanguage
#>   <chr>    <chr>                  <chr>         <dttm>              <fct>       
#> 1 Proposed Proposal:3D tagging f… 3D tagging f… 2025-09-06 17:57:58 en          
#> 2 Proposed Proposal:*:language-L… :<language>-… 2026-05-01 00:14:54 en          
#> 3 Proposed Proposal:Note suffix   :note suffix  2022-07-12 09:33:14 en          
#> 4 Proposed Proposal:Access key    access_key    2024-10-15 12:03:14 en          
#> 5 Proposed Proposal:Add language… Add language… 2024-11-13 09:49:37 en          
#> # ℹ 23 more variables: touched <dttm>, length <int>, fullurl <chr>,
#> #   editurl <chr>, pageid <int>, page_creator <fct>,
#> #   date_of_page_creation <dttm>, latest_editor <fct>,
#> #   date_of_latest_edit <dttm>, total_number_of_edits <dbl>,
#> #   total_number_of_distinct_authors <dbl>, proposal_status <fct>,
#> #   proposed_by <fct>, tagging <chr>, applies_to_node <lgl>,
#> #   applies_to_way <lgl>, applies_to_area <lgl>, applies_to_relation <lgl>, …
```

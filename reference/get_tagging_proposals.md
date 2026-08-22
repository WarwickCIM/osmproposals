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
#> Error in as.character(x): cannot coerce type 'closure' to vector of type 'character'
head(proposals)
#> # A tibble: 6 × 30
#>   status   title                  sortkeyprefix timestamp           pagelanguage
#>   <fct>    <chr>                  <chr>         <dttm>              <fct>       
#> 1 Rejected Proposal:Electricity   "\"electrici… 2022-03-15 02:38:02 en          
#> 2 Rejected Proposal:Motorcycle f… "\"tag motor… 2022-03-14 20:31:57 en          
#> 3 Rejected Proposal:Tramtrack on… "\"Tramtrack… 2022-03-15 03:40:16 en          
#> 4 Rejected Proposal:Amenity=loun… "Amenity=lou… 2024-10-30 16:40:54 en          
#> 5 Rejected Proposal:Aquatics cen… "Aquatics ce… 2022-03-14 15:18:12 en          
#> 6 Rejected Proposal:Artwork type… "artwork typ… 2022-03-15 22:24:41 en          
#> # ℹ 25 more variables: touched <dttm>, length <int>, fullurl <chr>,
#> #   editurl <chr>, pageid <int>, page_creator <fct>,
#> #   date_of_page_creation <dttm>, latest_editor <fct>,
#> #   date_of_latest_edit <dttm>, total_number_of_edits <dbl>,
#> #   total_number_of_distinct_authors <dbl>, proposal_status <fct>,
#> #   proposed_by <fct>, tagging <chr>, applies_to_node <lgl>,
#> #   applies_to_way <lgl>, applies_to_area <lgl>, applies_to_relation <lgl>, …
```

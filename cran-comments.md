## Resubmission

This is a resubmission. Our latest submission got flagged for not wrapping
Osmium Tool/Osmium in single quotes and for not adding a web reference to the
software.

## Test environments

- Local Ubuntu 22.04 installation (R 4.3.2)
- GitHub Actions:
  - Windows (release)
  - MacOS (release)
  - Ubuntu 20.04 (devel, release, oldrel)

## R CMD check results

0 errors | 0 warnings | 1 note

>  New submission
>  
>  Possibly misspelled words in DESCRIPTION:
>    OSM (9:28)
>    OpenStreetMap (9:13)

This is the first submission for rosmium. We believe the misspelled word note
is a false positive, since the words are correctly spelled. OSM is an acronym
for OpenStreetMap.

# IAPD

**install gems:** ` gem install rubyzip sqlite3 `


``` shell
rake download
```

Downloads SEC zip data. Creates file "form-adv-complete-ria.zip"

``` shell
rake csvs
```

Produces two csv -- advisors.csv and owners.csv -- from the zip file

``` shell
rake database
```

Creates "iapd.db", a sqlite database with 2 tables, advisors and owners, containing the information from the csvs.

``` shell
rake update_owners_table
```

Computes two new columns to the owners table: owner_key and advisor_crd_number.

``` shell
rake json
```

Creates advisors.json and owners.json. In advisors.json the key is the "crd" number and the values is an array of all advisors found with the same crd number. For owner.json the key is either the name or the crd number of the owner and values is an array of all owner that are the same.

``` shell
rake relationships
```
Produces relationships.csv, an list of ownership relationship.


### about the data

- [information](https://www.sec.gov/help/foiadocsinvafoiahtm.html)

- [form adv](https://www.sec.gov/about/forms/formadv-part1a.pdf)

- [csv files](https://www.sec.gov/foia/docs/form-adv-archive-data.htm)

# IAPD

**install gems:** ` gem install rubyzip sqlite3 `


``` shell
rake download
```

Downloads SEC zip data. Creates file "form-adv-complete-ria.zip"


``` shell
rake extract
```

Creates directory `data` with csvs

``` shell
rake csvs
```

Creates advisors.csv and owners.csv

``` shell
rake database
```

Creates iapd.db

### about the data

- [information](https://www.sec.gov/help/foiadocsinvafoiahtm.html)

- [form adv](https://www.sec.gov/about/forms/formadv-part1a.pdf)

- [csv files](https://www.sec.gov/foia/docs/form-adv-archive-data.htm)

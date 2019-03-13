CREATE TABLE advisors (
  name TEXT,
  dba_name TEXT,
  crd_number TEXT,
  sec_file_number TEXT,
  assets_under_management INTEGER,
  total_number_of_accounts INTEGER,
  filing_id INTEGER,
  date_submitted TEXT,
  filename TEXT
);

CREATE TABLE owners (
  filing_id INTEGER,
  scha_3 TEXT,
  schedule TEXT,
  name TEXT,
  owner_type TEXT,
  entity_in_which TEXT,
  title_or_status TEXT,
  acquired TEXT,
  ownership_code TEXT,
  control_person BOOLEAN,
  public_reporting BOOLEAN,
  owner_id TEXT,
  filename TEXT
);

.mode csv
.separator "|"
.import advisors.csv advisors
.import owners.csv owners

CREATE index owners_filing_id_idx on owners(filing_id);
CREATE index advisors_filing_id_idx on advisors(filing_id);
CREATE index advisors_assets_idx on advisors(assets_under_management);
CREATE index advisors_crd_number_idx on advisors(crd_number);

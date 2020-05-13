CREATE TABLE advisors_filings (
  name TEXT,
  dba_name TEXT,
  crd_number TEXT,
  sec_file_number TEXT,
  assets_under_management INTEGER,
  total_number_of_accounts INTEGER,
  filing_id INTEGER,
  date_submitted TEXT,
  filename TEXT,
  iapd_year TEXT,
  iapd_quarter TEXT
);

CREATE TABLE owners_filings (
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
  filename TEXT,
  iapd_year TEXT,
  iapd_quarter TEXT
);

.mode csv
.separator "|"
.import advisors.csv advisors_filings
.import owners.csv owners_filings

-- delete header rows
DELETE FROM advisors_filings WHERE name = 'name' AND dba_name = 'dba_name';
DELETE FROM owners_filings WHERE name = 'name' AND owner_type = 'owner_type';

CREATE TABLE advisors AS
select *
FROM (
	SELECT crd_number,
		json_group_array(distinct name) as names,
		json_group_array(distinct filing_id) as filing_ids,
		json_group_array(distinct sec_file_number) as sec_file_numbers
	FROM advisors_filings
	GROUP BY crd_number
) AS advisors_grouped_by_crd
INNER JOIN (
	SELECT distinct
		crd_number,
		first_value(filename) OVER filename_window AS first_filename,
		last_value(filename) OVER filename_window AS latest_filename,
		last_value(assets_under_management) OVER filename_window AS latest_aum,
		last_value(filing_id) OVER filename_window AS latest_filing_id
	from advisors_filings
	WINDOW filename_window AS (PARTITION by crd_number order by filename asc RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
) AS advisor_aggregate_stats ON advisors_grouped_by_crd.crd_number = advisor_aggregate_stats.crd_number;


CREATE TABLE owners_relationships AS
SELECT owners_filings.*,
       advisors_filings.advisor_crd_number,
       case when owner_id like 'XX%' OR owner_id = 'FOREIGN' then name else owner_id end as owner_key
FROM owners_filings
INNER JOIN (
	select filing_id, crd_number as advisor_crd_number
	from advisors_filings
	group by filing_id
) AS advisors_filings ON advisors_filings.filing_id = owners_filings.filing_id;


CREATE TABLE owners_schedule_a AS
SELECT json_group_array(
        json_object('filing_id', filing_id,
                    'schedule', schedule,
                    'scha_3', scha_3,
                    'name', name,
                    'owner_type', owner_type,
                    'title_or_status', title_or_status,
                    'acquired', acquired,
                    'ownership_code', ownership_code,
                    'control_person', control_person,
                    'public_reporting', public_reporting,
                    'owner_id', owner_id,
                    'filename', filename,
                    'iapd_year', iapd_year)
       ) AS records,
       json_group_array(filing_id) as filing_ids,
       owner_key,
       advisor_crd_number
FROM owners_relationships
WHERE schedule = 'A'
GROUP BY owner_key, advisor_crd_number;

CREATE TABLE owners_schedule_b AS
SELECT json_group_array(
        json_object('filing_id', filing_id,
                    'schedule', schedule,
                    'scha_3', scha_3,
                    'name', name,
                    'owner_type', owner_type,
                    'title_or_status', title_or_status,
                    'entity_in_which', entity_in_which,
                    'acquired', acquired,
                    'ownership_code', ownership_code,
                    'control_person', control_person,
                    'public_reporting', public_reporting,
                    'owner_id', owner_id,
                    'filename', filename,
                    'iapd_year', iapd_year)
       ) AS records,
       json_group_array(filing_id) as filing_ids,
       owner_key,
       advisor_crd_number
FROM owners_relationships
WHERE schedule = 'B'
GROUP BY owner_key, advisor_crd_number;


CREATE index advisors_crd_number_idx on advisors(crd_number);
CREATE index owners_relationships_advisor_crd_number_idx on owners_relationships(advisor_crd_number);
CREATE index owners_schedule_a_advisor_crd_number_idx on owners_schedule_a(advisor_crd_number);
CREATE index owners_schedule_a_owner_key_idx on owners_schedule_a(owner_key);
CREATE index owners_schedule_b_owner_key_idx on owners_schedule_b(owner_key);

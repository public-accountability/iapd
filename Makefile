##
# IAPD Data
# Requirements:
#   - ssconvert (from gnumeric)
#   - unzip
#   - curl
#   - sqlite3

ia_url := https://www.sec.gov/files/investment/data/information-about-registered-investment-advisers-and-exempt-reporting-advisers/ia090418.zip
update_ria :=https://www.sec.gov/foia/docs/adv/form-adv-quarterly-update-ria.zip
complete_ria := https://www.sec.gov/foia/docs/adv/form-adv-complete-ria.zip

CURL := curl -L -O

default:
	@echo 'IAPD'

index:
	sqlite3 ia090418.db < index.sql

# IA_Schedule_A_B_20180401_20180630

form-adv-quarterly-update-ria:
	mkdir -p form-adv-quarterly-update-ria
	unzip -j -d ./form-adv-quarterly-update-ria form-adv-quarterly-update-ria.zip
	find form-adv-quarterly-update-ria -type f -print0 | xargs -P 2 -0 -I FILE iso8859_to_utf8! FILE

form-adv-complete-ria:
	mkdir -p form-adv-complete-ria
	unzip -j -d ./form-adv-complete-ria form-adv-complete-ria.zip
	find form-adv-complete-ria -type f -print0 | xargs -P 2 -0 -I FILE iso8859_to_utf8! FILE

form-adv-complete-ria.zip:
	$(CURL) $(complete_ria)

form-adv-quarterly-update-ria.zip:
	$(CURL) $(update_ria)

ia090418.db:
	csvsql --db sqlite:///ia090418.db --insert ia090418.csv
	csvsql --db sqlite:///ia090418.db --insert form-adv-quarterly-update-ria/IA_Schedule_A_B_20180401_20180630.csv

ia090418.csv: ia090418.xlsx
	ssconvert ia090418.xlsx ia090418.csv

ia090418.xlsx: ia090418.zip
	unzip -f ia090418.zip

ia090418.zip:
	$(CURL) $(ia_url)

pry:
	pry -I. -e "require 'bundler/setup';Bundler.require"


.PHONY: pry index

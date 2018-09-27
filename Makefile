##
# IAPD Data
# Requirements:
#   - ssconvert (from gnumeric)
#   - uznip
#   - curl

ia_url := https://www.sec.gov/files/investment/data/information-about-registered-investment-advisers-and-exempt-reporting-advisers/ia090418.zip

default:
	@echo 'IAPD'

ia090418.csv: ia090418.xlsx
	ssconvert ia090418.xlsx ia090418.csv

ia090418.xlsx: ia090418.zip
	unzip -f ia090418.zip

ia090418.zip:
	curl -L -O $(ia_url)

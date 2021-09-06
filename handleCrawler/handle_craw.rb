# Import selenium driver
require File.dirname(__FILE__) + "/log"
require "selenium-webdriver"
require "json"
require 'csv'

class HandleCrawler
    
	# Begin: Function init driver
	def initDriver

		Log.info "Init driver"

		# Init driver for chrome browser
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument('--ignore-certificate-errors')
		options.add_argument('--ignore-ssl-errors')
		Selenium::WebDriver.logger.output = File.join("./tmp", "selenium.log")
		Selenium::WebDriver.logger.level = :warn
		Selenium::WebDriver.for :chrome, options: options
	end
	# End: Function init driver

	# Begin: Function start crawler
	def startCrawler
		driver = initDriver()

		# Init start page = 1 and end page = 278
		startPage = 1
		endPage = 278
		
		# Get last page crawl
		fileSize = File.size("./tmp/temp.txt")
		if fileSize > 0
			startPage = lastPageCrawl()
		end
		
		(startPage..endPage).each do |page|
			Log.info "Start craw data in page #{page}"

			#1 Get url website craw
			urlWebsiteCrawl = "https://www.telework-rule.metro.tokyo.lg.jp/search/index.php" + (page == 1 ? "" : "?page=#{page}")
			driver.get urlWebsiteCrawl

			#2 Get information outside the company
			sleep 3
			listCompany = getInfoOutsideOfCompany(driver, page)
		
			#3 Get information detail of company
			infoDetail = []
			listCompany.each do |company|
				urlDetail = company[:urlDetail]
				companyName = company[:companyName]
				idCompany = company[:id]
				infoDetail << getDetailInfoCompany(urlDetail, companyName, driver, page)
			end

			writeDataToCsvFile(infoDetail, page)
			writeTmpFile(page)
			Log.info "Craw data page #{page} success"
		end
		# end startPage..endPage.each do |page|

		Log.info "Craw data success"

	end
	# End: Function start crawler

	# Begin: Function get link detail and name company
	def getInfoOutsideOfCompany driver, page
		numCompany = 1
		elements = driver.find_elements(:css, ".company_name a")
		infoOutsideOfCompany = elements.map do |element|
			{
				urlDetail: element.attribute('href'),
				companyName: element.text,
				page: page
			}
		end
	end
	# End: Function get link detail and name company

	# Begin: Function get info detail of company
	def getDetailInfoCompany(urlDetail, companyName, driver, page)
		driver.get urlDetail
		sleep 3

		strInfoDetail = driver.find_element(:css, ".company_details .clearfix").text
		arrInfoDetail = strInfoDetail.split("\n")
		
		# Get value in arrInfoDetail and remove ":" charactor
		address = arrInfoDetail[0].split("所在地")[1]
		address[0] = ''
		category = arrInfoDetail[1].split("業種")[1]
		category[0] = ''
		size = arrInfoDetail[2].split("従業員規模")[1]
		size[0] = ''
		homePage = arrInfoDetail[3].split("HP")[1]
		homePage[0] = ''

		arrayInfoDetail =	{
			name: companyName, 
			url: urlDetail, 
			address: address, 
			category: category, 
			size: size, 
			homePage: homePage,
		}
	end
	# End: Function get info detail of company

	# Begin: Save data to file temp.txt
	def writeTmpFile(page)
		File.open("./tmp/temp.txt", "w") do |file|
			file.truncate(0)
			file.write(page)
		end
	end
	# End: Save data to file temp.txt

	# Begin: Write data to file csv
	def writeDataToCsvFile infoDetail, page
		CSV.open("data_craw.csv", "a+") do |csv|
			infoDetail.each do |company|
				csv << company.values
			end
		end
	end
	# End: Write data to file csv

	# Begin: Function get last page crawled
	def lastPageCrawl

		# Read num page saved in file temp.txt and startPage = strNumPage + 1
		strNumPage = (File.open("./tmp/temp.txt").read).to_i
		startPage = strNumPage + 1
	end
	# End: Function get last page crawled

end

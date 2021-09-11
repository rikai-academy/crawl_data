# Import selenium driver
require File.dirname(__FILE__) + "/log"
require "selenium-webdriver"
# require "socksify/http"
# require "watir"
require "json"
require 'csv'

class HandleCrawler
    
	# Begin: Function init driver
	def initDriver

		Log.info "Init driver"
		options = Selenium::WebDriver::Chrome::Options.new
		options.add_argument('--ignore-certificate-errors')
		options.add_argument('--ignore-ssl-errors')
		# options.add_experimental_option('excludeSwitches', ['enable-logging'])
		@wait = Selenium::WebDriver::Wait.new(timeout: 10)

		Selenium::WebDriver.logger.output = File.join("./tmp", "selenium.log")
		Selenium::WebDriver.logger.level = :warn
		Selenium::WebDriver.for :chrome, options: options

	end
	# End: Function init driver

	# Begin: Function start crawler
	def startCrawler
		driver = initDriver()		
		arrTotalNumPage = [391, 100, 399]

		startPage = 1
		namePageCrawling = ""

		# Get last page crawl
		sizeTempFile = File.size("./tmp/temp.txt")
		if sizeTempFile > 0

			# Get current name page crawling
			namePageCrawling = lastPageCrawl()

			sizeFileNumPage = File.size("./tmp/temp_#{namePageCrawling}.txt")
			if sizeFileNumPage > 0
				numPageCrawled = getNumPage("./tmp/temp_#{namePageCrawling}.txt")
			end

		end		

		if namePageCrawling != ""

			# Log.info "index"
			# Log.info "namePageCrawling 1 - #{namePageCrawling}"
			arrNamePageCraw = ['ct-web-system', 'ct-app-developer', 'ct-hp-design']
        index = arrNamePageCraw.find_index(namePageCrawling)
				# Log.info "namePageCrawling - #{namePageCrawling}"
				# Log.info "index2 - #{index}"
				# Log.info "numPageCrawled - #{numPageCrawled}"
				while index < 3
					case namePageCrawling
					when 'ct-web-system'
						endPage = arrTotalNumPage[0]
					when 'ct-app-developer'
						endPage = arrTotalNumPage[1]
					else
						endPage = arrTotalNumPage[2]
					end
					
					if numPageCrawled < endPage
						startPage = numPageCrawled + 1
						getInfoCompany(namePageCrawling, startPage, endPage, driver)
					end

					index = index+1
					namePageCrawling = arrNamePageCraw[index]
					numPageCrawled = 0
				end
		else
			arrTotalNumPage.each do |totalNumPage|
				endPage = totalNumPage

				case endPage
				when 391
					paramUrl = 'ct-web-system'
				when 100
					paramUrl = 'ct-app-developer'
				else
					paramUrl = 'ct-hp-design'
				end

				getInfoCompany(paramUrl, startPage, endPage, driver)
			end
			# End: arrTotalNumPage.each do |totalNumPage|

			Log.info "Craw data success"
		end
	end
	# End: Function start crawler

	# Begin: Function get info company
	def getInfoCompany paramUrl, startPage, endPage, driver
		Log.info "Connecting to https://imitsu.jp/#{paramUrl}/search/"
			(startPage..endPage).each do |page|
			
				Log.info "Start craw data in page #{page}"

				#1 Get url website craw
				urlWebsiteCrawl = "https://imitsu.jp/#{paramUrl}/search/" + (page == 1 ? "" : "?pn=#{page}")
				driver.get urlWebsiteCrawl

				#2 Get information outside the company
				sleep 3
				listCompany = getInfoOutsideOfCompany(driver)

				#3 Get information detail of company
				infoDetail = []
				listCompany.each do |company|
					urlDetail = company[:urlDetail]
					companyName = company[:companyName]
					infoDetail << getDetailInfoCompany(urlDetail, companyName, driver)
				end

				writeDataToCsvFile(infoDetail)
				writeTempURLFile(page, paramUrl)
				writeTempFile(paramUrl)

				Log.info "Craw data page #{page} success"
			end
			# end startPage..endPage.each do |page|
			Log.info "Craw data https://imitsu.jp/#{paramUrl} success"
	end
	# End: Function get info company

	# Begin: Function get link detail and name company
	def getInfoOutsideOfCompany driver
		numCompany = 1
		elements = driver.find_elements(:css, ".name a")
		infoOutsideOfCompany = elements.map do |element|
			{
				urlDetail: element.attribute('href'),
				companyName: element.text,
			}
		end
	end
	# End: Function get link detail and name company

	# Begin: Function get info detail of company
	def getDetailInfoCompany(urlDetail, companyName, driver)

		# Access to url detail
		driver.get urlDetail+"#target-info"
		sleep 2
		
		# Get service name
		serviceName = checkElement('#service-name .about2__data', driver)

		# Get size company
		size = checkElement('#service-item-50 .about2__data', driver)

		# Get link home page of company
		homePage = checkElement('#service-url .about2__data', driver)

		# Get start up year of company
		startupYear = checkElement('#service-item-49 .about2__data', driver)

		# Get budget of company
		budget = checkElement('#service-budget .about2__data', driver)

		arrayInfoDetail =	{
			name: companyName, 
			url: urlDetail, 
			serviceName: serviceName, 
			size: size, 
			homePage: homePage,
			startupYear: startupYear,
			budget: budget
		}
		
	end
	# End: Function get info detail of company

	# Begin: Function check element exist or no
	def checkElement attribute, driver
		begin
			driver.find_element(css: attribute).displayed?
			result = driver.find_element(css: attribute).text
		rescue => e
			result = ""
		end
	end
	# End: Function check element exist or no

	# Begin: Save data to file temp_parramUrl.txt
	def writeTempURLFile(page, paramUrl)
		File.open("./tmp/temp_#{paramUrl}.txt", "w") do |file|
			file.truncate(0)
			file.write(page)
		end
	end
	# End: Save data to file temp_parramUrl.txt

	# Begin: Save data to file temp.txt
	def writeTempFile(paramUrl)
		File.open("./tmp/temp.txt", "w") do |file|
			file.truncate(0)
			file.write(paramUrl)
		end
	end
	# End: Save data to file temp.txt

	
	# Begin: Write data to file csv
	def writeDataToCsvFile infoDetail
		CSV.open("data_craw.csv", "a+") do |csv|
			infoDetail.each do |company|
				csv << company.values
			end
		end
	end
	# End: Write data to file csv

	# Begin: Function get last page crawled
	def lastPageCrawl

		# get last page crawl
		strNamePage = File.open("./tmp/temp.txt").read

	end
	# End: Function get last page crawled

	# Begin: Function get numpage
	def getNumPage fileName
		strCurrentNumPage = (File.open(fileName).read).to_i
	end

end

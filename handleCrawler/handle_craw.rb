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
    @wait = Selenium::WebDriver::Wait.new(:timeout => 5)

		Selenium::WebDriver.logger.output = File.join("./tmp", "selenium.log")
		Selenium::WebDriver.logger.level = :warn
		Selenium::WebDriver.for :chrome, options: options
	end
	# End: Function init driver

	# Begin: Function start crawler
	def startCrawler
		driver = initDriver()

    #1 Get url website craw
    urlWebsiteCrawl = "https://ex-portal1.reed.jp/202110T/exhibitor/ESS_StnSyaIcrEngGmn.do"
    driver.get urlWebsiteCrawl
    sleep 3
    # Count num row data
    trElement = @wait.until { driver.find_elements(xpath: "/html/body/section/div/form/table[2]/tbody/tr/td/table/tbody/tr[4]/td/div/div/table[2]/tbody/tr") }
    numRow = trElement.size()

    arrInfo = []
    (1..numRow).each do |row|
      info = {
        name: "",
        url: ""
      }

      nameElement = @wait.until { driver.find_element(xpath: "/html/body/section/div/form/table[2]/tbody/tr/td/table/tbody/tr[4]/td/div/div/table[2]/tbody/tr[#{row}]/td[1]/a") }
      urlElement = @wait.until { driver.find_element(xpath: "/html/body/section/div/form/table[2]/tbody/tr/td/table/tbody/tr[4]/td/div/div/table[2]/tbody/tr[#{row}]/td[1]/a") }
      info[:name] = nameElement.text
      info[:url] = urlElement.attribute("href")

      arrInfo << info
    end

    arrayInfoDetail = []
    arrInfo.each do |info|
      driver.get info[:url]
      sleep 3

      arrInfoDetail = {
        name: info[:name],
        url: info[:url],
        website: "",
        email: "",
        phone: "",
        address: ""
      }

      arrInfoDetail[:website] = checkElementExist(driver, "#exhibitor_details_website p a")
      arrInfoDetail[:email] = checkElementExist(driver, "#exhibitor_details_email p a")
      arrInfoDetail[:phone] = checkElementExist(driver, "#exhibitor_details_phone p a")
      arrInfoDetail[:address] = checkElementExist(driver, "#exhibitor_details_address span")

      arrayInfoDetail << arrInfoDetail
    end

    # print arrayInfoDetail
    writeDataToCsvFile(arrayInfoDetail)

		Log.info "Craw data success"

	end
	# End: Function start crawler

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
	def checkElementExist driver, cssValue

		# Read num page saved in file temp.txt and startPage = strNumPage + 1
		begin
      element = @wait.until { driver.find_element(css: cssValue) }
      value = element.text
    rescue => exception
      value = ""
    end

    return value
	end
	# End: Function get last page crawled

end

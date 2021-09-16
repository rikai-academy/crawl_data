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
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
		Selenium::WebDriver.logger.output = File.join("./tmp", "selenium.log")
		Selenium::WebDriver.logger.level = :warn
		Selenium::WebDriver.for :chrome, options: options
	end
	# End: Function init driver

	# Begin: Function start crawler
	def startCrawler
		driver = initDriver()
		
    # 1 Create array categories
    arrayCategories = ['business-system', 'app-development', 'hp', 'ec-site', 'panfret-catalog', 'illustlation', 'video-production', 'ad-copy']

    # 2 Create array info company default: Ten cong ty, dia chi, so luong nhan vien, url, doanh thu
    arrayInfo = ['会社名', '住所', '従業員数', 'URL', '資本金']

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

      # Find key of name page crawling in arrayCategories
      index = arrayCategories.find_index(namePageCrawling)

      while index < arrayCategories.size
        Log.info "Start crawl category #{namePageCrawling}"

        sleep 2
        driver.get "https://rekaizen.com/#{namePageCrawling}"

        # Count num page
        paginateElement = driver.find_elements(css: ".pager li")
        numPage = paginateElement.size()

        if numPageCrawled < endPage
          startPage = numPageCrawled + 1
          getInfoCompany(startPage, numPage, namePageCrawling, driver, arrayInfo)
        end

        index = index+1
        namePageCrawling = arrayCategories[index]
        numPageCrawled = 0
      end
      Log.info "Crawl all data web imitsu success"

    else
      arrayCategories.each do |category|

        Log.info "Start crawl category #{category}"
  
        sleep 2
        driver.get "https://rekaizen.com/#{category}"
        
        startPage = 1

        # Count num page
        paginateElement = driver.find_elements(css: ".pager li")
        numPage = paginateElement.size()

        getInfoCompany(startPage, numPage, category, driver, arrayInfo)
      end
      Log.info "Crawl all data web imitsu success"
    end
	end
	# End: Function start crawler

	# Begin: Function get link detail and name company
	def getInfoCompany startPage, endPage, category, driver, arrayInfo
    (startPage..endPage).each do |page|

      sleep 2
      driver.get "https://rekaizen.com/#{category}" + (page == 1 ? "" : "?page=#{page}")
      
      # Get link detail company
      sleep 2
      detailCompanyUrl = @wait.until { driver.find_elements(css: ".list li a") }
      urlDetailCompany = detailCompanyUrl.map { |urlDetail| urlDetail.attribute("href") }

      Log.info "start crawl page #{page} of category #{category}"
      
      arrayDetailInfo = []

      urlDetailCompany.each do |company|
        
        # Access to the company
        driver.get company
        arrayDetailInfo << getDetailInfoCompany(arrayInfo, driver)
      end
      
      writeDataToCsvFile(arrayDetailInfo)
      writeTempURLFile(page, category)
      writeTmpFile(category)
      Log.info "Crawl success page #{page} of category #{category}"
    end
    Log.info "Crawl category #{category} is success"

	end
	# End: Function get link detail and name company

	# Begin: Function get info detail of company
	def getDetailInfoCompany(arrayInfo, driver)

    hashDetailInfo = {name: "", address: "", size: "", url: "", budget: ""}

		# Count num row info detail of company
    infoDetail = @wait.until { driver.find_elements(css: "#com_info table tbody tr") }
    numRowData = infoDetail.size()

    # arrayInfo
    (1..numRowData).each do |numRow|

      dataName = driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/th").text
      if arrayInfo.include?(dataName)
        if dataName == '会社名'
          contentInfo = @wait.until { driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/td") }
          hashDetailInfo[:name] = contentInfo.text
          next
        end

        if dataName == '住所'
          contentInfo = @wait.until { driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/td") }
          hashDetailInfo[:address] = contentInfo.text
          next
        end

        if dataName == '従業員数'
          contentInfo = @wait.until { driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/td") }
          hashDetailInfo[:size] = contentInfo.text
          next
        end

        if dataName == 'URL'
          contentInfo = @wait.until { driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/td/a") }
          hashDetailInfo[:url] = contentInfo.text
          next
        end

        if dataName == '資本金'
          contentInfo = @wait.until { driver.find_element(xpath: "/html/body/div[1]/main/div[4]/div[2]/div/div/div[2]/section[@id='com_info']/table/tbody/tr[#{numRow}]/td") }
          hashDetailInfo[:budget] = contentInfo.text
          next
        end
      end
    end
    print hashDetailInfo
    return hashDetailInfo
	end
	# End: Function get info detail of company

	# Begin: Save data to file temp.txt
	def writeTmpFile(category)
		File.open("./tmp/temp.txt", "w") do |file|
			file.truncate(0)
			file.write(category)
		end
	end
	# End: Save data to file temp.txt

  # Begin: Save data to file temp_parramUrl.txt
	def writeTempURLFile(page, paramUrl)
		File.open("./tmp/temp_#{paramUrl}.txt", "w") do |file|
			file.truncate(0)
			file.write(page)
		end
	end
	# End: Save data to file temp_parramUrl.txt

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

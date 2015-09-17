module ScrapeUtils

  @session_id = nil

  # Generic headers
  def headers
    {
      'Accept-Language' => 'en-US,en;q=0.5',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Connection' => 'keep-alive',
      'DNT' => '1',
      'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:32.0) Gecko/20100101 Firefox/32.0'
    }
  end

  def post_headers
    headers.merge({
      'Cache-Control' => 'no-cache',
      'Pragma' => 'no-cache',
      'Referer' => 'https://www.turbus.cl/wtbus/indexCompra.jsf'
    })
  end

  # Parameters for requests
  def cities_params(date)
    {
      'AJAX:EVENTS_COUNT' => '1',
      'AJAXREQUEST' => 'j_id_id18',
      'ajaxSingle' => 'j_id_id89:j_id_id112',
      'autoScroll' =>'',
      'inputvalue' =>'',
      'j_id_id89:calIdaInputCurrentDate' => date.strftime('%m/%Y'),
      'j_id_id89:calIdaInputDate' => date.strftime('%d/%m/%Y'),
      'j_id_id89:calVueltaInputCurrentDate' => date.strftime('%m/%Y'),
      'j_id_id89:calVueltaInputDate' => date.strftime('%d/%m/%Y'),
      'j_id_id89:cantidadPasajes' => '1',
      'j_id_id89:cmbCiudadDestino' => '',
      'j_id_id89:cmbCiudadOrigen' => ' ' ,
      'j_id_id89:ida_y_vuelta' => 'IDA_VUELTA',
      'j_id_id89:j_id_id112' => 'j_id_id89:j_id_id112',
      'j_id_id89:j_id_id112_selection' =>'',
      'j_id_id89:j_id_id143_selection' =>'',
      'j_id_id89' => 'j_id_id89',
      'javax.faces.ViewState' => 'j_id1'
    }
  end

  def best_prices_params(origin, destination, date)
    {
      'AJAXREQUEST' => 'j_id_id18',
      'autoScroll' =>'',
      'j_id_id89:botonContinuar' => 'j_id_id89:botonContinuar',
      'j_id_id89:calIdaInputCurrentDate' => date.strftime('%m/%Y'),
      'j_id_id89:calIdaInputDate' => date.strftime('%d/%m/%Y'),
      'j_id_id89:calVueltaInputCurrentDate' => date.strftime('%m/%Y'),
      'j_id_id89:calVueltaInputDate' => date.strftime('%d/%m/%Y'),
      'j_id_id89:cantidadPasajes' => '1',
      'j_id_id89:cmbCiudadDestino' => destination,
      'j_id_id89:cmbCiudadOrigen' => origin,
      'j_id_id89:ida_y_vuelta' => 'IDA',
      'j_id_id89:j_id_id112_selection' =>'',
      'j_id_id89:j_id_id143_selection' =>'',
      'j_id_id89' => 'j_id_id89',
      'javax.faces.ViewState' => 'j_id1'
    }
  end

  def best_price_row_params(best_price_row)
    {
      'AJAXREQUEST' => "#{best_price_row}:j_id_id405",
      'j_id_id347' => 'j_id_id347',
      "#{best_price_row}:lnkR0" => "#{best_price_row}:lnkR0",
      'javax.faces.ViewState' => 'j_id2'
    }
  end

  def itineraries_params
    {
      'AJAXREQUEST' => 'j_id_id10',
      'autoScroll' =>'',
      'botonera:j_id_id551' => 'botonera:j_id_id551',
      'botonera:mpErrorsOpenedState' => '',
      'botonera' => 'botonera',
      'javax.faces.ViewState' => 'j_id2'
    }
  end

  def base_itinerary_params
    {
      'AJAXREQUEST' => 'j_id_id9',
      'autoScroll' => '',
      'j_id_id345:mpErrorsOpenedState' => '',
      'j_id_id345:mpViggoMessageOpenedState' => '',
      'j_id_id345:waitOpenedState' => '',
      'j_id_id345' => 'j_id_id345',
      'javax.faces.ViewState' => 'j_id3'
    }
  end

  def select_itinerary_params(position)
    base_itinerary_params.merge({position => position})
  end

  def itinerary_page_params(page = 'last')
    base_itinerary_params.merge({
      'AJAX:EVENTS_COUNT' => '1',
      'ajaxSingle' => 'j_id_id345:scrollerIda',
      'j_id_id345:scrollerIda' => page
    })
  end

  def seats_params
    base_itinerary_params.merge({
      'j_id_id345:j_id_id819' => 'j_id_id345:j_id_id819'
    })
  end

  # Xpaths and css to scrape info
  def cities_xpath
    '//*[@id="j_id_id89:j_id_id112:suggest"]/tbody/tr/td'
  end

  def best_prices_xpath
    '//*[@id="j_id_id347:tblmejorPrecioIda:tb"]/tr'
  end

  def best_prices_link_xpath
    '//td/span/table/tbody/tr'
  end

  def itineraries_xpath
    '//*[@id="j_id_id345:itinerarioIDA:tb"]'
  end

  def itinerary_pages_xpath
    '//*[@id="j_id_id345:scrollerIda_table"]'
  end

  def error_xpath
    '//*[@id="botonera:j_id_id528"]'
  end

  def best_prices_link_css
    '.rich-table-row'
  end

  def itinerary_pages_css
    '[@id="j_id_id345:scrollerIda_table"] td.rich-datascr-inact'
  end

  def seats_css
    '[@id="frmSeleccionAsientos:dtblContenedor:0:dtblAsientos2:tb"] td.rich-asientos'
  end

  def scraping_setup
    RestClient.proxy = 'http://localhost:54271'

    @session_id = RestClient::Resource.new(
      ENV['index_url'], verify_ssl: false, headers: headers
    ).get.cookies['JSESSIONID']
  end

  %w{index best_price itinerary seat}.each do |variable|
    define_method "post_#{variable}" do |params|
      post_turbus_data(ENV["#{variable}_url"], params)
    end
  end

  def post_turbus_data(url, params)
    # puts "#{url}?#{params.to_s}"
    RestClient::Resource.new(url,
      verify_ssl: false,
      cookies: {'JSESSIONID' => @session_id },
      headers: post_headers
      # ).post(params)
      ).post(params){ |response, request, result, &block|
        if response.code == 200
          response.return!(request, result, &block)
        else
          logger.error("#{request.inspect}, #{result.inspect}")
          # response.follow_redirection(request, result, &block)
          nil
        end
      }
  end

  def logger
    @@logger ||= Logger.new( File.join(Rails.root, "log/scraping.log") )
  end

end

require 'scraperwiki'
require 'spidey'

HOST = 'http://www.parksandgardens.org'
URL = "#{HOST}/places-and-people/sites/atoz"


class ParksSpider < Spidey::AbstractSpider
  handle URL, :parse_atoz

  def parse_atoz(page, default_data = {})
    page.search('#parksandgardens a').each do |link|
      handle resolve_url(link.attr('href'), page), :parse_list
    end
  end

  def parse_list(page, default_data = {})
    page.search('.sites-list a').each do |park_link|
      path = park_link.attribute('href').value
      name = park_link.text
      id = path.split('/').last
      record name: name, url: HOST + path, id: id
    end

    next_link = agent.page.link_with(text: 'next')
    handle resolve_url(next_link.href, page), :parse_list if next_link
  end
end

spider = ParksSpider.new
spider.crawl # max_urls: 10

spider.results.each { |data| ScraperWiki.save_sqlite([:id], data) }

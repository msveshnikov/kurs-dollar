# encoding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile


  def index
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      #f.title(text: "Динамика курсов")

      params[:month]=1 if !params[:month]
      @rates=Rate.where(date: params[:month].to_i.month.ago..Date.today)
      @dollar=@rates.last.dollar.round(2)
      @euro=@rates.last.euro.round(2)
      @oil=@rates.last.oil
      f.xAxis(categories: @rates.map { |v| v.date.to_s[0..9] })

      f.series(name: "Доллар", yAxis: 0, data: @rates.map { |v| v.dollar })
      f.series(name: "Евро", yAxis: 0, data: @rates.map { |v| v.euro })
      f.series(name: "Нефть", yAxis: 0, data: @rates.map { |v| v.oil })

      f.yAxis [{ title: { text: "Курс доллара/евро", margin: 20 } }]
      #{ title: { text: "Цена на нефть $/барр" }, opposite: true } ]

      f.legend(width: 320, floating: true,
               align: 'left', x: 0, y: 0, itemWidth: 80, borderWidth: 1)
      f.chart({ width: mobile_device? ? 340 : 800, marginBottom: 120, defaultSeriesType: "line" })
    end
  end
end

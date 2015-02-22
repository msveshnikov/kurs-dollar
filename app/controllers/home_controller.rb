# encoding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile


  def index
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "Динамика курсов")

      params[:month]=1 if !params[:month]
      @rates=Rate.where(date: params[:month].to_i.month.ago..Date.today)
      @dollar=@rates.last.dollar
      @euro=@rates.last.euro
      @oil=@rates.last.oil
      f.xAxis(categories: @rates.map { |v| v.date.to_s[0..9] })
      f.series(name: "Курс доллара", yAxis: 0, data: @rates.map { |v| v.dollar })
      @e = @rates.map { |v| v.euro }
      #@e.shift
      f.series(name: "Курс евро", yAxis: 0, data: @e)
      f.series(name: "Цена на нефть", yAxis: 0, data: @rates.map { |v| v.oil })

      f.yAxis [{ title: { text: "Курс доллара/евро", margin: 30 } }]
      #{ title: { text: "Цена на нефть $/барр" }, opposite: true } ]

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical',)
      f.chart({ defaultSeriesType: "line" })
    end
  end
end

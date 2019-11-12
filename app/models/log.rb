class Log < ApplicationRecord
  has_many_attached :uploads
  
  has_many :inputs
  belongs_to :game
  belongs_to :user
  has_one :computer
  
  def parse_upload
    require 'csv'
    inputs_fps = []
    inputs_frametime = []
    maxstring = ",{'data':{"
    minstring = "{'data':{"
    avgstring = ",{'data':{"
    onepercentstring = ",{'data':{"
    bar_chart = ""
    data_fps = []
    data_fps_only = []
    allMax = []
    allMin = []
    uploads.attachments.each_with_index do |upload, i|
      if upload.color == nil 
        upload.update(color: Bench::TWENTY[i])
      end
      data_fps = []
      data_fps_only = []
      data_frametime = []
      parsed = CSV.parse(upload.download)
      if parsed[0][0] == "os"
        if self.computer.nil?
          Computer.create(os: parsed[1][0], cpu: parsed[1][1], gpu: parsed[1][2], ram: parsed[1][3],
          kernel: parsed[1][4], driver: parsed[1][5], log_id: self.id, user_id: self.user_id)
        end
      end
      parsed.each_with_index do |parse, i|
        if i > 2
          data_fps.push([i, parse[0]])
          data_fps_only.push(parse[0].to_i)
          data_frametime.push([i, (1000 / parse[0].to_f).round(2)])
        end
      end
      fpsSorted = data_fps.map{ |object| object[1]}.sort_by(&:to_i)
      onePercent = fpsSorted[0..(fpsSorted.count * 0.1) - 1]
      fpsTotalSorted = 0
      onePercent.each do |fps|
        fpsTotalSorted = fpsTotalSorted + fps.to_i
      end
      fpsTotal = 0
      data_fps_only.each do |fps|
        fpsTotal = fpsTotal + fps.to_i
      end
      allMax.push(data_fps_only.max)
      allMin.push(data_fps_only.min)
      fpsTotal / data_fps.count
      if i == (uploads.attachments.count - 1)
        maxstring = maxstring               + "'#{upload.filename.to_s}': #{data_fps_only.max}"
        minstring = minstring               + "'#{upload.filename.to_s}': #{data_fps_only.min}"
        onepercentstring = onepercentstring + "'#{upload.filename.to_s}': #{(fpsTotalSorted / onePercent.count).to_s}"
        avgstring = avgstring               + "'#{upload.filename.to_s}': #{(fpsTotal / data_fps.count).to_s}"
      else
        maxstring = maxstring + "'#{upload.filename.to_s}': #{data_fps_only.max},"
        minstring = minstring + "'#{upload.filename.to_s}': #{data_fps_only.min},"
        onepercentstring = onepercentstring + "'#{upload.filename.to_s}': #{(fpsTotalSorted / onePercent.count).to_s},"
        avgstring = avgstring + "'#{upload.filename.to_s}': #{(fpsTotal / data_fps_only.count).to_s},"
      end
      
      inputs_fps.push(name: upload.filename.to_s, data: data_fps, color: upload.color)
      inputs_frametime.push(name: upload.filename.to_s, data: data_frametime, color: upload.color)
      upload.update(min: data_fps_only.min, max: data_fps_only.max, avg: fpsTotal / data_fps_only.count, onepercent: fpsTotalSorted / onePercent.count)
      end
      maxstring = maxstring               + "}, 'name':'Max'}"
      minstring = minstring               + "}, 'name':'Min'}"
      avgstring = avgstring               + "}, 'name':'Avg'}"
      onepercentstring = onepercentstring + "}, 'name':'1% min'}"
      bar_chart = "[" + minstring + onepercentstring + avgstring + maxstring  + "]"
      bar_chart = bar_chart.tr("'", '"')
      if self.uploads.count > 1
        if self.compare_to == nil
          self.update(compare_to: uploads.blobs.order(:id).first.id)
        end
      else
        self.update(compare_to: nil)
      end
      self.update(fps: inputs_fps.chart_json, frametime: inputs_frametime.chart_json, bar: bar_chart, max: allMax.max, min: allMin.min)
  end
  
  def refresh_json
    inputs.where(fps: 0).delete_all
      names = Log.last.inputs.pluck(:name).uniq
      fps_chart       = names.map { |name| {name: name, data: inputs.where(name: name).group(:pos).average(:fps)}}.chart_json
      frametime_chart = names.map { |name| {name: name, data: inputs.where(name: name).group(:pos).average(:frametime)}}.chart_json
      bar_chart = [
              {
                name: 'Max',
                data: inputs.group(:name).maximum(:fps),
              },
              {
                name: 'Avg',
                data: inputs.group(:name).average(:fps),
              },
              {
                name: 'Min',
                data: inputs.group(:name).minimum(:fps),
              }
            ]
      self.update(fps: fps_chart, frametime: frametime_chart, bar: bar_chart)
      self.inputs.delete_all
    end
end

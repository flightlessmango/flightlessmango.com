class Log < ApplicationRecord
  has_many_attached :uploads
  
  has_many :inputs
  belongs_to :game
  belongs_to :user
  has_one :computer

  def is_float?(fl)
    !!Float(fl) rescue false
  end
  
  def parse_upload(type)
    require 'csv'
    fps_row = 0
    cpu_row = 0
    inputs_fps = []
    inputs_frametime = []
    inputs_cpu = []
    inputs_cpuavg = []
    maxstring = ',{"data":{'
    minstring = '{"data":{'
    avgstring = ',{"data":{'
    onepercentstring = '{"data":{'
    percentile97 = ',{"data":{'
    cpuavg = '['
    bar_chart = ""
    data_fps = []
    data_fps_only = []
    data_cpu = []
    data_cpu_only = []
    allMax = []
    allMin = []
    uploads.attachments.each_with_index do |upload, i|
      upload.update(display_name: upload.filename.to_s) if upload.display_name.nil?
      if upload.color == nil 
        upload.update(color: Bench::TWENTY[i])
      end
      data_fps = []
      data_fps_only = []
      data_frametime = []
      data_cpu = []
      data_cpu_only = []
      parsed = CSV.parse(upload.download)

        if parsed[0][0] == "os" && parsed[1][0] != nil
          if self.computer.nil?
            Computer.create(os: parsed[1][0], cpu: parsed[1][1], gpu: parsed[1][2], ram: parsed[1][3],
            kernel: parsed[1][4], driver: parsed[1][5], log_id: self.id, user_id: self.user_id)
          end
        end
      if self.computer != nil
        if self.computer.cpu == nil
          self.computer.delete
        end
      end
      if upload.filename.extension == "hml"
        parsed.each_with_index do |parse, i|
          1000.times do |x|
            if parse[x] == "Framerate           "
              fps_row = x
            end
            if parsed[0][i] == "CPU usage           "
              cpu_row = x
            end
          end
        end
        count = 0
        parsed.each_with_index do |parse, i|
          unless parse[fps_row] == nil || parse[fps_row] == "Framerate           "
            # 5.times do
            if is_float?(parse[fps_row])
              data_fps.push([count, parse[fps_row]])
              data_fps.push([count, parse[cpu_row]])
              data_fps_only.push(parse[fps_row].to_i)
              data_frametime.push([count, (1000 / parse[fps_row].to_f).round(2)])
              count += 1
            end
            # end
          end
          
        end
        
      else
        count = 0
        parsed.each_with_index do |parse, i|
          if i > 2
            data_fps.push([count, parse[0]])
            data_cpu.push([count, parse[1]])
            data_cpu_only.push(parse[1])
            data_fps_only.push(parse[0].to_i)
            data_frametime.push([count, (1000 / parse[0].to_f).round(2)])
            count += 1
          end
        end
      end
      fpsSorted = data_fps.map{ |object| object[1]}.sort_by(&:to_i)
      onePercent = fpsSorted[0..(fpsSorted.count * 0.1) - 1]
      fpsTotalSorted = 0
      onePercent.each do |fps|
        fpsTotalSorted = fpsTotalSorted + fps.to_i
      end
      fpsTotal = 0
      cpuTotal = 0
      data_fps_only.each do |fps|
        fpsTotal = fpsTotal + fps.to_i
      end
      data_cpu_only.each do |cpu|
        cpuTotal = cpuTotal + cpu.to_i
      end
      allMax.push(data_fps_only.max)
      allMin.push(data_fps_only.min)
      fpsTotal / data_fps.count
      if i == (self.uploads.attachments.count - 1)
        # maxstring = maxstring               + '"' + display_name + '"' + ": #{data_fps_only.max}"
        # minstring = minstring               + '"' + display_name + '"' + ": #{data_fps_only.min}"
        percentile97 = percentile97         + '"' + upload.display_name + '"' + ": #{Bench.percentile(data_fps_only.sort, 0.97)}"
        onepercentstring = onepercentstring + '"' + upload.display_name + '"' + ": #{(fpsTotalSorted / onePercent.count).to_s}"
        avgstring = avgstring               + '"' + upload.display_name + '"' + ": #{(fpsTotal / data_fps.count).to_s}"
        # cpuavg = cpuavg + '["' + upload.display_name + '"' +  ',"' + (cpuTotal / data_cpu_only.count).to_s + '"' + '"' + ']'
      else
        # maxstring = maxstring               + '"' + display_name + '"' + ": #{data_fps_only.max},"
        # minstring = minstring               + '"' + display_name + '"' + ": #{data_fps_only.min},"
        percentile97 = percentile97         + '"' + upload.display_name + '"' + ": #{Bench.percentile(data_fps_only.sort, 0.97)},"
        onepercentstring = onepercentstring + '"' + upload.display_name + '"' + ": #{(fpsTotalSorted / onePercent.count).to_s},"
        avgstring = avgstring               + '"' + upload.display_name + '"' + ": #{(fpsTotal / data_fps.count).to_s},"
        # cpuavg = cpuavg + '["' + upload.display_name + '"' +  ',' + '"' + (cpuTotal / data_cpu_only.count).to_s + '"' + '],'
      end
      
      
      inputs_fps.push(name: upload.display_name, data: data_fps, color: upload.color)
      inputs_cpu.push(name: upload.display_name, data: data_cpu, color: upload.color)
      inputs_frametime.push(name: upload.display_name, data: data_frametime, color: upload.color)
      upload.update(min: data_fps_only.min, max: data_fps_only.max, avg: fpsTotal / data_fps_only.count, onepercent: fpsTotalSorted / onePercent.count,
        percentile97: Bench.percentile(data_fps_only.sort, 0.97))
      end
      maxstring = maxstring               + '}, "name":"Max"}'
      minstring = minstring               + '}, "name":"Min"}'
      avgstring = avgstring               + '}, "name": "Avg"}'
      onepercentstring = onepercentstring + '}, "name": "1% min"}'
      percentile97 = percentile97         + '}, "name": "97th percentile"}'
      bar_chart = "[" + onepercentstring + avgstring + percentile97  + "]"
      bar_chart = bar_chart.tr("'", '"')
      cpuavg = cpuavg + ']'
      if self.uploads.count > 1
        if self.compare_to == nil
          self.update(compare_to: uploads.blobs.order(:id).first.id)
        end
      else
        self.update(compare_to: nil)
      end
      if type == "other"
        self.update!(fps: inputs_fps.chart_json, frametime: inputs_frametime.chart_json, bar: bar_chart, max: allMax.max,
          min: allMin.min, cpu: inputs_cpu.chart_json, cpuavg: cpuavg, computer: self.computer)
      else
        self.update!(fps: inputs_fps.chart_json, frametime: inputs_frametime.chart_json, bar: bar_chart, max: allMax.max,
          min: allMin.min, cpu: inputs_cpu.chart_json, cpuavg: cpuavg)
      end
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

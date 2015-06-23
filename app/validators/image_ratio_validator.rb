class ImageRatioValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    soft   = options[:throttle] || 0.0
    ratio  = options[:ratio]
    width  = options[:width].to_s
    height = options[:height].to_s
    fix    = options[:fix] || false

    if record[width].nil? or record[height].nil?
      return nil
    else
      record[width] = record[width].to_i.abs
      record[height] = record[height].to_i.abs
      if record[width] == 0 or record[height] == 0 or record[width] == nil or record[height] == nil
        record.errors[attribute] << 'Illegal Image Ratio'
        return nil
      end

      that = record[width].to_f / record[height].to_f
      if (ratio - that).abs > soft
        if fix and (ratio.round - that.round).abs == 0
          return nil
        end
        record.errors[attribute] << 'Illegal Image Ratio'
      end
    end
  end
end

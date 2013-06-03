module Jekyll
  module LineTruncate
    def truncateline(input, length=10, replacement="......")
      num = 0
      tmp = ""
      lines = input.lines
      if lines.to_a.length < length then return input end

      lines.each do |line|
        if num >= length then break end
        num += 1
        tmp += line
      end
      return tmp.chop + replacement
    end
  end
end

Liquid::Template.register_filter(Jekyll::LineTruncate)

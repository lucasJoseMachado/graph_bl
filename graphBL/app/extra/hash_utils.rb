class HashUtils
  def self.load_json_file file_path
    file = File.read(file_path)
    JSON.parse(file)
  end
end

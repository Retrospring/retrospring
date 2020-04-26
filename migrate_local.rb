#!bin/rails runner

ActiveStorage::Attachment.find_each do |attachment|
  name = attachment.name

  source = attachment.record.send(name).path
  dest_dir = File.join(
    "storage",
    attachment.blob.key.first(2),
    attachment.blob.key.first(4).last(2))
  dest = File.join(dest_dir, attachment.blob.key)

  FileUtils.mkdir_p(dest_dir)
  puts "#{source} -> #{dest}"
  FileUtils.cp(source, dest)
end
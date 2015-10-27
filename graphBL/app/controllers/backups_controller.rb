class BackupsController < ApplicationController
  def restore
    Rails.cache.write("proposing", true)
    Rails.cache.delete("propose")
    system "rake backup:restore"
    Rails.cache.delete("proposing")
    render nothing: true
  end
end

json.array!(@thing_tags) do |ti|
  json.extract! ti, :id, :thing_id, :tag_id, :creator_id, :created_at, :updated_at
  json.thing_name ti.thing_name        if ti.respond_to?(:thing_name)
  json.tag_name ti.tag_name  if ti.respond_to?(:tag_name)
end

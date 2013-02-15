# encoding: utf-8

def insert_user  
  User.truncate!
  password = Rails.env.production? ? Devise.friendly_token : (1..9).to_a.join
  
  admin = User.new do |u|
    u.name = "Administrator"
    u.email = 'dev@fodojo.com'
    u.password = password
    u.password_confirmation = password
    u.login = 'admin' if u.respond_to?(:login)
    u.role_type = RoleType.admin
  end
    
  admin.skip_confirmation!
  admin.save!

  puts "Admin: #{admin.email}, #{admin.password}"
end

def insert_structures
  Structure.truncate!
  
  main_page = Structure.create!(title: "Главная страница", slug: "main-page", structure_type: StructureType.main, parent: nil)
  # Structure.create!(title: "Трансляции", slug: "broadcasts", structure_type: StructureType.broadcasts, parent: main_page)
end

insert_user
insert_structures

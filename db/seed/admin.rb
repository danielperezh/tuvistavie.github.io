Admin.create(
  email: 'tuvistavie@gmail.com',
  password: 'foobar',
  password_confirmation: 'foobar',
  small_picture: 'small_profile_spiakt.jpg',
  large_picture: 'large_profile_ksdgjt.jpg',
  first_name: 'Daniel',
  last_name: 'Perez',
  nickname: 'tuvistavie'
) unless Admin.exists?(email: 'tuvistavie@gmail.com')

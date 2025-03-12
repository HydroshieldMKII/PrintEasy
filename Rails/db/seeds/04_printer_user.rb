# frozen_string_literal: true

# Get users
admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

PrinterUser.create!(user: admin, printer: Printer.find_by(model: 'Bambulab'), acquired_date: Time.new(2022, 1, 15))
PrinterUser.create!(user: admin, printer: Printer.find_by(model: 'Anycubic'), acquired_date: Time.new(2022, 5, 22))
PrinterUser.create!(user: admin, printer: Printer.find_by(model: 'Artillery'), acquired_date: Time.new(2023, 2, 10))
PrinterUser.create!(user: admin, printer: Printer.find_by(model: 'Creality'), acquired_date: Time.new(2023, 8, 5))
PrinterUser.create!(user: admin, printer: Printer.find_by(model: 'Elegoo'), acquired_date: Time.new(2024, 3, 20))

PrinterUser.create!(user: user1, printer: Printer.find_by(model: 'Prusa'), acquired_date: Time.new(2022, 3, 10))
PrinterUser.create!(user: user1, printer: Printer.find_by(model: 'Qidi'), acquired_date: Time.new(2022, 11, 28))
PrinterUser.create!(user: user1, printer: Printer.find_by(model: 'Sindoh'), acquired_date: Time.new(2023, 4, 15))
PrinterUser.create!(user: user1, printer: Printer.find_by(model: 'Ultimaker'), acquired_date: Time.new(2023, 10, 2))
PrinterUser.create!(user: user1, printer: Printer.find_by(model: 'XYZprinting'), acquired_date: Time.new(2024, 1, 8))
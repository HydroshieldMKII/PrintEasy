
printers = %w[Bambulab Anycubic Artillery Creality Elegoo Flashforge Monoprice Prusa Qidi
              Sindoh Ultimaker XYZprinting Zortrax]
printers.each do |printer|
  Printer.create!(model: printer)
end
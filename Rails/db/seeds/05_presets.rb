admin = User.find_by(username: 'aaadmin')
user1 = User.find_by(username: 'aaa')

# Create Presets
presets = [
  { color: Color.find_by(name: 'Red'), filament: Filament.find_by(name: 'PETG'), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: 'Blue'), filament: Filament.find_by(name: 'TPU'), user: user1, print_quality: 0.12 },
  { color: Color.find_by(name: 'Green'), filament: Filament.find_by(name: 'Nylon'), user: admin, print_quality: 0.16 },
  { color: Color.find_by(name: 'Yellow'), filament: Filament.find_by(name: 'Wood'), user: user1, print_quality: 0.2 },
  { color: Color.find_by(name: 'Black'), filament: Filament.find_by(name: 'Metal'), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: 'White'), filament: Filament.find_by(name: 'Carbon Fiber'), user: user1, print_quality: 0.12 },
  { color: Color.find_by(name: 'Orange'), filament: Filament.find_by(name: 'PETG'), user: admin, print_quality: 0.16 },
  { color: Color.find_by(name: 'Purple'), filament: Filament.find_by(name: 'TPU'), user: user1, print_quality: 0.2 },
  { color: Color.find_by(name: 'Pink'), filament: Filament.find_by(name: 'Nylon'), user: admin, print_quality: 0.08 },
  { color: Color.find_by(name: 'Brown'), filament: Filament.find_by(name: 'Wood'), user: user1, print_quality: 0.12 }
]

presets.each do |preset|
  Preset.create!(preset)
end
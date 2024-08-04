#===============================================================================
# Walking charset, for use in text entry screens and load game screen
#===============================================================================
class TrainerWalkingCharSprite < AnimatedSprite
  def initialize(charset,viewport=nil,trainer=nil)
    @trainer=trainer
    clothing_sheet = generateClothedBitmapStatic(trainer)
    super clothing_sheet, 4, clothing_sheet.width/4, clothing_sheet.height/4, 5
  end
end

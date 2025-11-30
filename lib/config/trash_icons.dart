enum TrashType {
  plastic,
  glass,
  paper,
  metal,
  organic,
  electronic,
}

class ModernTrashIcons {
  static const Map<TrashType, String> icons = {
    TrashType.plastic: '🔄', // Renewable plastic icon
    TrashType.glass: '⚗️',  // Lab glass icon
    TrashType.paper: '📄',  // Clean paper icon
    TrashType.metal: '🔩',  // Engineering metal icon
    TrashType.organic: '🍃', // Organic leaf icon
    TrashType.electronic: '🔌', // Electronics icon
  };
}

class EcoTrashIcons {
  static const Map<TrashType, String> ecoIcons = {
    TrashType.plastic: '♻️', // Recycle symbol
    TrashType.glass: '🌊',  // Sea glass
    TrashType.paper: '🌳',  // Tree paper
    TrashType.metal: '⚡',  // Energy metal
    TrashType.organic: '🌱', // Growth organic
    TrashType.electronic: '📱', // Modern electronics
  };
}

class AnimatedTrashIcons {
  static const Map<TrashType, List<String>> animatedIcons = {
    TrashType.plastic: ['🔄', '⏳', '✅'], // Plastic -> Recycled
    TrashType.glass: ['⚗️', '✨', '💎'],  // Polishing
    TrashType.paper: ['📄', '📊', '📚'],  // Paper -> Product
    TrashType.metal: ['🔩', '⚙️', '🏗️'], // Metal -> Construction
    TrashType.organic: ['🍃', '🍂', '🌱'], // Leaf -> Compost -> Sprout
    TrashType.electronic: ['🔌', '🔋', '💡'], // Plug -> Battery -> Light
  };
}

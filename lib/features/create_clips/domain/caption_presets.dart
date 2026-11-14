/// Static catalog backing the "Quick presets" caption-style gallery. There's
/// no API for this yet — these are the 17 styles + "No caption" shown in the
/// web dashboard screenshots, with their Trending/New badges.
class CaptionPresetOption {
  final String id;
  final String label;
  final String? badge;

  const CaptionPresetOption({
    required this.id,
    required this.label,
    this.badge,
  });
}

const List<CaptionPresetOption> kCaptionPresets = [
  CaptionPresetOption(id: 'none', label: 'No caption'),
  CaptionPresetOption(
    id: 'highlight_pill',
    label: 'Highlight Pill',
    badge: 'Trending',
  ),
  CaptionPresetOption(id: 'karaoke', label: 'Karaoke', badge: 'Trending'),
  CaptionPresetOption(id: 'beast_mode', label: 'Beast Mode', badge: 'Trending'),
  CaptionPresetOption(id: 'one_word', label: 'One-Word', badge: 'New'),
  CaptionPresetOption(id: 'hormozi', label: 'Hormozi', badge: 'Trending'),
  CaptionPresetOption(id: 'clean_bar', label: 'Clean Bar', badge: 'New'),
  CaptionPresetOption(id: 'neon_glow', label: 'Neon Glow', badge: 'New'),
  CaptionPresetOption(id: 'typewriter', label: 'Typewriter', badge: 'New'),
  CaptionPresetOption(id: 'comic_pop', label: 'Comic Pop', badge: 'New'),
  CaptionPresetOption(id: 'aesthetic', label: 'Aesthetic', badge: 'New'),
  CaptionPresetOption(id: '3d_block', label: '3D Block', badge: 'New'),
  CaptionPresetOption(id: 'bubble', label: 'Bubble', badge: 'New'),
  CaptionPresetOption(id: 'elegant', label: 'Elegant', badge: 'New'),
  CaptionPresetOption(id: 'marker', label: 'Marker', badge: 'New'),
  CaptionPresetOption(id: 'glitch', label: 'Glitch', badge: 'New'),
  CaptionPresetOption(id: 'gradient_pop', label: 'Gradient Pop', badge: 'New'),
  CaptionPresetOption(id: 'classic', label: 'Classic'),
];

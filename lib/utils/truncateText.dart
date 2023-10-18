String truncateText(String str, int max) {
  return str.length <= max ? str : '${str.substring(0, max)}...';
}

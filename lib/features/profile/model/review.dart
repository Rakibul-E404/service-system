// Review Model
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final int rating;
  final String date;
  final String comment;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
  });
}
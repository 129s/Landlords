class BidUpdateDTO {
  final String roomId;
  final int currentBid;
  final int bidderId;

  BidUpdateDTO({
    required this.roomId,
    required this.currentBid,
    required this.bidderId,
  });

  factory BidUpdateDTO.fromJson(Map<String, dynamic> json) {
    return BidUpdateDTO(
      roomId: json['roomId'],
      currentBid: json['currentBid'],
      bidderId: json['bidderId'],
    );
  }
}

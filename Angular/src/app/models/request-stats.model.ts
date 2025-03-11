export type RequestStatsApi = {
  preset_id: number | null;
  preset_quality: number | null;
  color_name: string;
  filament_name: string;
  total_offers: number;
  accepted_offers: number;
  acceptance_rate_percent: number;
  total_accepted_price: number;
  avg_price_diff: number;
};

export class RequestStatsModel {
  presetId: number | null;
  presetQuality: number | null;
  colorName: string;
  filamentName: string;
  totalOffers: number;
  acceptedOffers: number;
  acceptanceRatePercent: number;
  totalAcceptedPrice: number;
  avgPriceDiff: number;

  constructor(
    presetID: number | null,
    presetQuality: number | null,
    colorName: string,
    filamentName: string,
    totalOffers: number,
    acceptedOffers: number,
    acceptanceRatePercent: number,
    totalAcceptedPrice: number,
    avgPriceDiff: number
  ) {
    this.presetId = presetID;
    this.presetQuality = presetQuality;
    this.colorName = colorName;
    this.filamentName = filamentName;
    this.totalOffers = totalOffers;
    this.acceptedOffers = acceptedOffers;
    this.acceptanceRatePercent = acceptanceRatePercent;
    this.totalAcceptedPrice = totalAcceptedPrice;
    this.avgPriceDiff = avgPriceDiff;
  }

  static fromAPI(data: RequestStatsApi): RequestStatsModel {
    return new RequestStatsModel(
      data.preset_id,
      data.preset_quality,
      data.color_name,
      data.filament_name,
      data.total_offers,
      data.accepted_offers,
      data.acceptance_rate_percent,
      data.total_accepted_price,
      data.avg_price_diff
    );
  }
}

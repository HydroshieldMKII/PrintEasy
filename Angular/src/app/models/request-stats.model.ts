export type RequestStatsApi = {
  preset_id: number | null;
  preset_quality: number | null;
  color_name: string;
  color_id: number;
  filament_name: string;
  filament_id: number;
  total_offers: number;
  accepted_offers: number;
  acceptance_rate_percent: number;
  total_accepted_price: number;
  avg_price_diff: number;
  avg_response_time_hours: number;
};

export class RequestStatsModel {
  presetId: number | null;
  presetQuality: number | null;
  colorName: string;
  colorId: number;
  filamentName: string;
  filamentId: number;
  totalOffers: number;
  acceptedOffers: number;
  acceptanceRatePercent: number;
  totalAcceptedPrice: number;
  avgPriceDiff: number;
  avgResponseTimeHours: number;

  constructor(
    presetID: number | null,
    presetQuality: number | null,
    colorName: string,
    colorId: number,
    filamentName: string,
    filamentId: number,
    totalOffers: number,
    acceptedOffers: number,
    acceptanceRatePercent: number,
    totalAcceptedPrice: number,
    avgPriceDiff: number,
    avgResponseTimeHours: number
  ) {
    this.presetId = presetID;
    this.presetQuality = presetQuality;
    this.colorName = colorName;
    this.colorId = colorId;
    this.filamentName = filamentName;
    this.filamentId = filamentId;
    this.totalOffers = totalOffers;
    this.acceptedOffers = acceptedOffers;
    this.acceptanceRatePercent = acceptanceRatePercent;
    this.totalAcceptedPrice = totalAcceptedPrice;
    this.avgPriceDiff = avgPriceDiff;
    this.avgResponseTimeHours = avgResponseTimeHours;
  }

  static fromAPI(data: RequestStatsApi): RequestStatsModel {
    return new RequestStatsModel(
      data.preset_id,
      data.preset_quality,
      data.color_name,
      data.color_id,
      data.filament_name,
      data.filament_id,
      data.total_offers,
      data.accepted_offers,
      data.acceptance_rate_percent,
      data.total_accepted_price,
      data.avg_price_diff,
      data.avg_response_time_hours
    );
  }
}


export type UserLeaderboardApi = {
    username: string;
    total_likes: number;
    participations: number;
    wins_count: number;
    winrate: number;
    submission_rate: number;
}
    
export class UserLeaderboardModel {
    username!: string;
    wins!: number;
    participations!: number;
    winRate!: number;
    totalLikes!: number;
    submissionsParticipationRate!: number;

    constructor(username: string, wins: number, participations: number, winRate: number, totalLikes: number, submissionsParticipationRate: number) {
        this.username = username;
        this.wins = wins;
        this.participations = participations;
        this.winRate = winRate;
        this.totalLikes = totalLikes;
        this.submissionsParticipationRate = submissionsParticipationRate;
    }
    
    static fromApi(userLeaderboardApi: UserLeaderboardApi): UserLeaderboardModel {
        return new UserLeaderboardModel(
            userLeaderboardApi.username, 
            userLeaderboardApi.wins_count, 
            userLeaderboardApi.participations, 
            userLeaderboardApi.winrate, 
            userLeaderboardApi.total_likes, 
            userLeaderboardApi.submission_rate
        );
    }
}



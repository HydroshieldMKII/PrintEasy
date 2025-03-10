
export type UserLeaderboardApi = {
    username: string;
    likes_received_count: number;
    contests_count: number;
    wins_count: number;
    winrate: number;
    submissions_participation_rate: number;
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
            userLeaderboardApi.contests_count, 
            userLeaderboardApi.winrate, 
            userLeaderboardApi.likes_received_count, 
            userLeaderboardApi.submissions_participation_rate
        );
    }
}



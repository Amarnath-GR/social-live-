import { Controller, Get, Post, Body, Param, Req } from '@nestjs/common';
import { WalletService } from './wallet.service';

@Controller()
export class WalletController {
  constructor(private walletService: WalletService) {}

  @Get('balance')
  async getBalance(@Req() req: any) {
    return this.walletService.getBalance(req.user.id);
  }

  @Get('transactions')
  async getTransactions(@Req() req: any) {
    return this.walletService.getTransactions(req.user.id);
  }

  @Post('deposit')
  async deposit(@Body() body: { amount: number }, @Req() req: any) {
    return this.walletService.deposit(req.user.id, body.amount);
  }

  @Post('withdraw')
  async withdraw(@Body() body: { amount: number }, @Req() req: any) {
    return this.walletService.withdraw(req.user.id, body.amount);
  }

  @Post('transfer')
  async transfer(@Body() body: { toUserId: string; amount: number }, @Req() req: any) {
    return this.walletService.transfer(req.user.id, body.toUserId, body.amount);
  }
}
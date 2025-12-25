import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Injectable()
export class WalletService {
  constructor(private prisma: PrismaService) {}

  async getBalance(userId: string) {
    try {
      const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
      return { success: true, data: { balance: wallet?.balance || 0 } };
    } catch (error) {
      return { success: false, error: 'Failed to get balance' };
    }
  }

  async getTransactions(userId: string) {
    try {
      const transactions = await this.prisma.walletTransaction.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 50,
      });
      return { success: true, data: { transactions } };
    } catch (error) {
      return { success: false, error: 'Failed to get transactions' };
    }
  }

  async deposit(userId: string, amount: number) {
    try {
      const result = await this.prisma.$transaction(async (tx) => {
        const wallet = await tx.wallet.upsert({
          where: { userId },
          create: { userId, balance: amount },
          update: { balance: { increment: amount } },
        });

        const transaction = await tx.walletTransaction.create({
          data: {
            userId,
            amount,
            type: 'CREDIT',
            status: 'COMPLETED',
            description: 'Deposit',
          },
        });

        return { wallet, transaction };
      });

      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: 'Deposit failed' };
    }
  }

  async withdraw(userId: string, amount: number) {
    try {
      const result = await this.prisma.$transaction(async (tx) => {
        const wallet = await tx.wallet.findUnique({ where: { userId } });
        
        if (!wallet || wallet.balance < amount) {
          throw new Error('Insufficient balance');
        }

        const updatedWallet = await tx.wallet.update({
          where: { userId },
          data: { balance: { decrement: amount } },
        });

        const transaction = await tx.walletTransaction.create({
          data: {
            userId,
            amount,
            type: 'DEBIT',
            status: 'COMPLETED',
            description: 'Withdrawal',
          },
        });

        return { wallet: updatedWallet, transaction };
      });

      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message || 'Withdrawal failed' };
    }
  }

  async transfer(fromUserId: string, toUserId: string, amount: number) {
    try {
      const result = await this.prisma.$transaction(async (tx) => {
        const fromWallet = await tx.wallet.findUnique({ where: { userId: fromUserId } });
        
        if (!fromWallet || fromWallet.balance < amount) {
          throw new Error('Insufficient balance');
        }

        await tx.wallet.update({
          where: { userId: fromUserId },
          data: { balance: { decrement: amount } },
        });

        await tx.wallet.upsert({
          where: { userId: toUserId },
          create: { userId: toUserId, balance: amount },
          update: { balance: { increment: amount } },
        });

        const debitTx = await tx.walletTransaction.create({
          data: {
            userId: fromUserId,
            amount,
            type: 'DEBIT',
            status: 'COMPLETED',
            description: `Transfer to ${toUserId}`,
          },
        });

        const creditTx = await tx.walletTransaction.create({
          data: {
            userId: toUserId,
            amount,
            type: 'CREDIT',
            status: 'COMPLETED',
            description: `Transfer from ${fromUserId}`,
          },
        });

        return { debitTx, creditTx };
      });

      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: error.message || 'Transfer failed' };
    }
  }
}
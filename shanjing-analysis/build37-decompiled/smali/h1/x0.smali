.class public abstract Lh1/x0;
.super Lh1/v0;
.source "SourceFile"


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lh1/v0;-><init>()V

    return-void
.end method


# virtual methods
.method protected final A()V
    .locals 2

    invoke-virtual {p0}, Lh1/x0;->y()Ljava/lang/Thread;

    move-result-object v0

    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v1

    if-eq v1, v0, :cond_0

    invoke-static {}, Lh1/c;->a()Lh1/b;

    invoke-static {v0}, Ljava/util/concurrent/locks/LockSupport;->unpark(Ljava/lang/Thread;)V

    :cond_0
    return-void
.end method

.method protected abstract y()Ljava/lang/Thread;
.end method

.method protected final z(JLh1/w0$a;)V
    .locals 1

    sget-object v0, Lh1/n0;->j:Lh1/n0;

    invoke-virtual {v0, p1, p2, p3}, Lh1/w0;->L(JLh1/w0$a;)V

    return-void
.end method

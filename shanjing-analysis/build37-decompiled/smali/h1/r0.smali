.class final Lh1/r0;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/util/concurrent/Executor;


# instance fields
.field public final d:Lh1/f0;


# virtual methods
.method public execute(Ljava/lang/Runnable;)V
    .locals 2

    iget-object v0, p0, Lh1/r0;->d:Lh1/f0;

    sget-object v1, Ls0/h;->d:Ls0/h;

    invoke-virtual {v0, v1, p1}, Lh1/f0;->g(Ls0/g;Ljava/lang/Runnable;)V

    return-void
.end method

.method public toString()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lh1/r0;->d:Lh1/f0;

    invoke-virtual {v0}, Lh1/f0;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

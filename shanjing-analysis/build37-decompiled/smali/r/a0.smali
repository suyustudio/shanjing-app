.class public final synthetic Lr/a0;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lj0/j;

.field public final synthetic e:Lr/i;

.field public final synthetic f:Lj0/k$d;


# direct methods
.method public synthetic constructor <init>(Lj0/j;Lr/i;Lj0/k$d;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/a0;->d:Lj0/j;

    iput-object p2, p0, Lr/a0;->e:Lr/i;

    iput-object p3, p0, Lr/a0;->f:Lj0/k$d;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    iget-object v0, p0, Lr/a0;->d:Lj0/j;

    iget-object v1, p0, Lr/a0;->e:Lr/i;

    iget-object v2, p0, Lr/a0;->f:Lj0/k$d;

    invoke-static {v0, v1, v2}, Lr/c0;->k(Lj0/j;Lr/i;Lj0/k$d;)V

    return-void
.end method

.class public final synthetic Lr/u;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lj0/j;

.field public final synthetic e:Lj0/k$d;

.field public final synthetic f:Lr/i;


# direct methods
.method public synthetic constructor <init>(Lj0/j;Lj0/k$d;Lr/i;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/u;->d:Lj0/j;

    iput-object p2, p0, Lr/u;->e:Lj0/k$d;

    iput-object p3, p0, Lr/u;->f:Lr/i;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    iget-object v0, p0, Lr/u;->d:Lj0/j;

    iget-object v1, p0, Lr/u;->e:Lj0/k$d;

    iget-object v2, p0, Lr/u;->f:Lr/i;

    invoke-static {v0, v1, v2}, Lr/c0;->e(Lj0/j;Lj0/k$d;Lr/i;)V

    return-void
.end method

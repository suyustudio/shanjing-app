.class public final synthetic Lu/g;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lu/i;

.field public final synthetic e:Lj0/j;

.field public final synthetic f:Lj0/k$d;


# direct methods
.method public synthetic constructor <init>(Lu/i;Lj0/j;Lj0/k$d;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lu/g;->d:Lu/i;

    iput-object p2, p0, Lu/g;->e:Lj0/j;

    iput-object p3, p0, Lu/g;->f:Lj0/k$d;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    iget-object v0, p0, Lu/g;->d:Lu/i;

    iget-object v1, p0, Lu/g;->e:Lj0/j;

    iget-object v2, p0, Lu/g;->f:Lj0/k$d;

    invoke-static {v0, v1, v2}, Lu/i;->c(Lu/i;Lj0/j;Lj0/k$d;)V

    return-void
.end method

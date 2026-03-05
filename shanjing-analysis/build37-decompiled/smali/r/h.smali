.class public final synthetic Lr/h;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lr/i;


# direct methods
.method public synthetic constructor <init>(Lr/i;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lr/h;->d:Lr/i;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    iget-object v0, p0, Lr/h;->d:Lr/i;

    invoke-static {v0}, Lr/i;->d(Lr/i;)V

    return-void
.end method
